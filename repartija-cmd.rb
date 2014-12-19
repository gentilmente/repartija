
def Preparar_listas()
    $aportes = [52,65,0,0,44]
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
    $acreedores.each do |a|
        $acumulado = 0
        puts
        puts "Para acreedor: " + a.to_s
        $deudores.each do |d|
            if(d > 0 && a < 0)
                puts "el deudor: " + ( $deudores.index( d ) + 1 ).to_s
                puts $acumulado += $pago_individual
                puts $resta_pagar = $acumulado + a
                if( $resta_pagar > 0 && $resta_pagar < $pago_individual)
                    puts "Paga: " + ($pago_individual - $resta_pagar).to_s
                    $acreedores[$acreedores.index(a)] += $pago_individual - $resta_pagar
                    $deudores[$deudores.index(d)] = $resta_pagar
                elsif (d < $pago_individual)
                    puts "ppaga: " + d.to_s
                    $acreedores[$acreedores.index(a)] += d
                    $deudores[$deudores.index(d)] =  0
                elsif ( $resta_pagar > $pago_individual)
                    puts "No paga"
                    $deudores[$deudores.index(d)] =  $pago_individual
                else
                    puts "paga: " + $pago_individual.to_s
                    $deudores[$deudores.index(d)] =  0
                    $acreedores[$acreedores.index(a)] += $pago_individual
                end
                #puts $resta_pagar
            else
                $deudores[$deudores.index(d)] =  0
            end
            puts '- -- - -- - -- -'
            puts $acreedores.to_s
            puts $deudores.to_s
            puts '- -- - -- - -- -'
        end
    end 
end

Preparar_listas()
Separar_lista()
Calcular()
