
def Preparar_listas()
    $aportes = [123,123,0,0,0,0]
    puts $aportes.to_s
    puts "Total: " 
    puts $total = $aportes.reduce(:+)
    puts "Pago individual: " 
    puts $pago_individual = $total/$aportes.count
    $saldos = $aportes.map {|e| $pago_individual - e }
end

def Separar_lista()
    $acreedores, $deudores = $saldos.partition { |e| e < 0 }
    puts '- -- - -- - -- -'
    puts "acreedores: "
    puts $acreedores.to_s
    puts "deudores: "
    puts $deudores.to_s 
    puts '- -- - -- - -- -'
end

def Calcular()
    $acreedores.map! do |a|
        $acumulado = 0
        puts
        puts "Para acreedor: " + a.to_s
        $deudores.map! do |d|
            if(d > 0 && a < 0)
                puts "el deudor: " + ( $deudores.index( d ) + 1 ).to_s
                $acumulado += $pago_individual
                $resta_pagar = $acumulado + a
                if( $resta_pagar > 0 && $resta_pagar < $pago_individual)
                    puts "Paga: " + ($pago_individual - $resta_pagar).to_s
                    a += $pago_individual - $resta_pagar
                    d = $resta_pagar
                elsif (d < $pago_individual)
                    puts "ppaga: " + d.to_s
                    a += d
                    d = 0
                elsif ( $resta_pagar > $pago_individual)
                    puts "No paga"
                    d = $pago_individual
                else
                    puts "paga: " + $pago_individual.to_s
                    d = 0
                    a += $pago_individual
                end
                #puts $resta_pagar
            else
                d = 0
            end
            #puts $resta_pagar
        end
        #$deudores.delete_if { |e| e < 0}
        puts '- -- - -- - -- -'
        puts $acreedores.to_s
        puts $deudores.to_s
        puts '- -- - -- - -- -'
    end 
end

Preparar_listas()
Separar_lista()
Calcular()
